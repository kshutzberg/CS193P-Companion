//
//  CS193PInstructorTableViewController.m
//  CS193P Companion
//
//  Created by Kevin Shutzberg on 11/29/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "CS193PInstructorTableViewController.h"
#import "LecturesTableViewController.h"
#import "TopicsTableViewController.h"
#import "Entities+Create.h"
#import "QuestionSearchTableViewController.h"

@interface CS193PInstructorTableViewController()<QuestionSearchTableViewControllerDelegate>
@property (nonatomic, strong) UIManagedDocument *databaseDocument;

@property (weak, nonatomic) IBOutlet UITableViewCell *lectureCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *topicCell;

- (void)useDocumentWithCompletionHandler:(void (^)(UIManagedDocument *document))completion;

@end

@implementation CS193PInstructorTableViewController
@synthesize databaseDocument = _databaseDocument;
@synthesize lectureCell = _lectureCell;
@synthesize topicCell = _topicCell;
 

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    BOOL showLectures = [segue.identifier isEqualToString:@"showLectures"];
    BOOL showTopics = [segue.identifier isEqualToString:@"showTopics"];
    
    if(showLectures || showTopics)
    {
        CoreDataTableViewController *destinationTableViewController = segue.destinationViewController;
        
        NSString *entity;
        NSArray *descriptors;
        
        //Configure destination specific attributes
        if(showLectures){
            destinationTableViewController.title = @"Lectures";
            entity = ENTITY_LECTURE;
            NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lectureName" ascending:YES];
            descriptors = [NSArray arrayWithObject:nameDescriptor];
        }
        else if(showTopics){
            destinationTableViewController.title = @"Topics";
            entity = ENTITY_TOPIC;
            NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"topicName" ascending:YES];
            descriptors = [NSArray arrayWithObject:nameDescriptor];
        }
        
        //Set up the FetchedResultsController:
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entity];
        request.sortDescriptors = descriptors;
        
        [self useDocumentWithCompletionHandler:^(UIManagedDocument *document){
            
            destinationTableViewController.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:document.managedObjectContext.parentContext sectionNameKeyPath:nil cacheName:nil]; 
            
        }];

    }
    else if([segue.identifier isEqualToString:@"showQuestionSearch"]){
        NSArray *viewControllers = [(UINavigationController *)segue.destinationViewController viewControllers];
        for (UIViewController *VC in viewControllers) {
            if ([VC isKindOfClass:[QuestionSearchTableViewController class]]) {
                QuestionSearchTableViewController *searchTVC = (QuestionSearchTableViewController *)VC;
                searchTVC.delegate = self;
                //searchTVC.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(userDidCancel)];
            }
        }
        
    }
    
}
- (IBAction)askQuestion:(id)sender {
    QuestionSearchTableViewController *searchTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"searchQuestions"];
    searchTVC.delegate = self;
    [self presentModalViewController:[[UINavigationController alloc] initWithRootViewController:searchTVC] animated:YES];
}

- (void)addTestDataToDocument:(UIManagedDocument *)document
{
    //Answers {Answer 1, Answer 2, Answer 3}
    NSArray *answers = [[NSArray alloc] initWithObjects:[Answer answerWithString:@"Answer 1" inContext:document.managedObjectContext],
                        [Answer answerWithString:@"Answer 2" inContext:document.managedObjectContext],[Answer answerWithString:@"Answer 3" inContext:document.managedObjectContext],[Answer answerWithString:@"Answer 4" inContext:document.managedObjectContext],[Answer answerWithString:@"Answer 5" inContext:document.managedObjectContext], nil];
    
    //Lecture: {Lecture 1, Lecture 2, Lecture: Core Data}
    Lecture *lecture = [Lecture lectureWithName:@"Lecture 1" andNumber:1 inContext:document.managedObjectContext];
    [Lecture lectureWithName:@"Lecture 2" andNumber:2 inContext:document.managedObjectContext];
    [Lecture lectureWithName:@"Lecture: Core Data" andNumber:3 inContext:document.managedObjectContext];
    
    //Topics: {Core Data, Foundation}
    NSArray *topics = [[NSArray alloc] initWithObjects:[Topic topicWithString:@"Core Data" inContext:document.managedObjectContext], [Topic topicWithString:@"Foundation" inContext:document.managedObjectContext], nil];
    
    
    [Question questionWithName:@"Test question" andPrompt:@"What answer should I choose?" andTime:30 andAnswers:answers forLecture:lecture withTopics:topics inManagedObjectContext:self.databaseDocument.managedObjectContext];
    
    [document saveToURL:document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:NULL];
}

- (void)useDocumentWithCompletionHandler:(void (^)(UIManagedDocument *document))completion
{
    if(!completion)completion = ^(UIManagedDocument *document){};
    
    //Lazily instantiate the document
    NSFileManager *manager = [NSFileManager defaultManager];
    if(!self.databaseDocument){
        NSURL *documentsURL = [[manager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        
#define DATABASE_NAME @"datamodel"
        
        self.databaseDocument = [[UIManagedDocument alloc] initWithFileURL:[documentsURL URLByAppendingPathComponent:DATABASE_NAME]];
    }
    
    //If the file does not exist on disk, create it:
    if (![manager fileExistsAtPath:self.databaseDocument.fileURL.path]) {
        [self.databaseDocument saveToURL:self.databaseDocument.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if(success)completion(self.databaseDocument);
            else NSLog(@"File creation failed");
        }];
    }
    
    //If the file is not open yet, open it:
    else if(self.databaseDocument.documentState == UIDocumentStateClosed){
        [self.databaseDocument openWithCompletionHandler:^(BOOL success) {
            if(success)completion(self.databaseDocument);
            else NSLog(@"Failed to open file");
            
        }];
    }
    
    else if(self.databaseDocument.documentState == UIDocumentStateNormal){
        completion(self.databaseDocument);
    }
}


#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.lectureCell.detailTextLabel.text = @" ";
    self.topicCell.detailTextLabel.text = @" ";
    
    [self useDocumentWithCompletionHandler:^(UIManagedDocument *document) {
        NSFetchRequest *lectureRequest = [NSFetchRequest fetchRequestWithEntityName:ENTITY_LECTURE];
        NSFetchRequest *topicRequest = [NSFetchRequest fetchRequestWithEntityName:ENTITY_TOPIC];
        
        int numLectures = [document.managedObjectContext countForFetchRequest:lectureRequest error:NULL];
        int numTopics = [document.managedObjectContext countForFetchRequest:topicRequest error:NULL];
        
        self.lectureCell.detailTextLabel.text = [NSString stringWithFormat:@"%i Lectures",numLectures];
        self.topicCell.detailTextLabel.text = [NSString stringWithFormat:@"%i Topics",numTopics];
        
    }];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Question search table view delegate

-(void)userDidCancel
{
    [self dismissModalViewControllerAnimated:YES];
}


@end
